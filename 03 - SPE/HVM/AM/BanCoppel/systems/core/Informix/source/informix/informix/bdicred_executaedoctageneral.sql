CREATE PROCEDURE "informix".executaedoctageneral(pempresa CHAR(3),pfechahoy DATE) 
--- EXECUTE PROCEDURE executaedoctageneral('001',MDY('09','20','2022'));
RETURNING CHAR(5);

--------------------------------------------------------
--	VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
DEFINE sql_err          INTEGER;
DEFINE v_cod_ret	    CHAR(5);
DEFINE v_corta_retorno  INTEGER;
--------------------------------------------------------
--	VARIABLES GENERALES
--------------------------------------------------------
DEFINE v_empresa        CHAR(3);
DEFINE v_num_credito    CHAR(20);
DEFINE v_num_producto   CHAR(4);

DEFINE v_id_registro    CHAR(3);
DEFINE v_descripcion 	CHAR(50);

DEFINE v_periodo_anterior   	DATE;			--Fecha Periodo Anterior
DEFINE v_dias_periodo_tc 		INTEGER;		--dias_periodo_tc
DEFINE v_texto		            CHAR(1000);
DEFINE v_clave           		INTEGER;
DEFINE v_secuencia        		INTEGER;
DEFINE v_mensajes				VARCHAR(255);

DEFINE GLOBAL v_cat			    DECIMAL(18,2) DEFAULT 0;
DEFINE GLOBAL v_cat2			DECIMAL(18,2) DEFAULT 0;
DEFINE GLOBAL v_cat3			DECIMAL(18,2) DEFAULT 0;
DEFINE GLOBAL v_linea_auxiliar	DECIMAL(14,2) DEFAULT 0;
DEFINE GLOBAL v_corta_linea_mensaje 	INTEGER  DEFAULT 0;

DEFINE dFechaIni				DATE;
DEFINE dFechaFin				DATE;
DEFINE cNumCredito				CHAR(20);

DEFINE vTextoNotas              CHAR(666);
DEFINE idTxt                    CHAR(02);
DEFINE vMensajesN               VARCHAR(255);
DEFINE vTerminoG	CHAR(125); -- PALABRA CLAVE DEL GLOSARIO.
DEFINE vTextoG		CHAR(475); -- SIGNIFICADO DE LA PALABRA CLAVE.
DEFINE vMensajesGlos	CHAR(255); 
DEFINE vCortaRetornoG	INTEGER;
DEFINE totglos		INTEGER;
DEFINE totglospte	INTEGER;
DEFINE vClaveGlos	INTEGER;
DEFINE vSecGlos		INTEGER;
DEFINE v_contador   INTEGER;
DEFINE v_inciso     CHAR(1);
DEFINE total_msj	INTEGER;

--------------------------------------------------------
--	INICIALIZACION VARIABLES
--------------------------------------------------------
LET sql_err          = "";
LET v_cod_ret	    = "000";

LET v_empresa        = "";
LET v_num_credito    = "";
LET v_num_producto   = "";

LET v_id_registro    = "";
LET v_descripcion 	= "";

LET v_periodo_anterior   	= " ";  --Fecha Periodo Anterior
LET v_dias_periodo_tc 		= 0;	--dias_periodo_tc
LET v_cat                   = 0; --- CAT
LET v_cat2                   = 0; --- CAT
LET v_cat3                   = 0; --- CAT Oro
LET v_texto                 = "";
LET v_linea_auxiliar        =999999.00;
LET v_mensajes				= "";
LET v_corta_retorno 		= 0;
LET v_corta_linea_mensaje 	= 113; -- AJUSTE PARA MENSAJES EN CAJA DE TEXTO
LET cNumCredito				= "";

LET vMensajesN		= "";
LET vTextoNotas     = "";
LET idTxt			= '';
LET vTerminoG		= '';
LET vTextoG			= ''; 
LET vMensajesGlos	= '';
LET vCortaRetornoG	= 0;
LET totglos			= 0;
LET totglospte		= 0;
LET vClaveGlos		= 0;
LET vSecGlos		= 0;
LET v_contador  	= 0;
LET v_inciso		= '';
LET total_msj		= 0;

---- -SET ISOLATION TO COMMITTED READ LAST COMMITTED;
--SET ISOLATION COMMITTED READ;

BEGIN


  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_cod_ret = sql_err;
			DROP TABLE IF EXISTS mensajes_imp;
			DROP TABLE IF EXISTS notas;
			DROP TABLE IF EXISTS mensajes_glos;
            RETURN v_cod_ret;
        END IF
   END EXCEPTION;


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	--------------------------------------------------------------
	-----EJECUTA PROCESO LLENADO DE TABLA SD_MUESTRA_EDOCTA-------
	--------------------------------------------------------------
	EXECUTE PROCEDURE "informix".executaedoctageneral_muestra('001','01-01-1990')
	INTO v_cod_ret,v_mensajes;
	
	EXECUTE PROCEDURE "informix".sp_edocta_credsol_detalle('001',pfechahoy)
	INTO v_cod_ret;
   -----------------------------------------------------   
   -----------------NUMERO DE PRODUCTO------------------
   -----------------------------------------------------

    SELECT {+ INDEX (bdicred:sd_definicion)} num_producto 
	INTO v_num_producto FROM bdicred:"informix".sd_definicion
    WHERE empresa = pempresa AND nombre_prod = TRIM('TARJETA CREDITO BANCOPPEL VISA');

	-------------------------------------------------------
	--SE INICIALIZA TABLA PARA EDOCTAS
	------------------------------------------------------
	---Truncate sd_movhisedocta;
    --------------------------------------------------------
	--SE OBTIENE FECHA HOY MENOS UN MES
	--------------------------------------------------------
	EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(pfechahoy,-1,DAY(pfechahoy))
	INTO v_cod_ret,v_periodo_anterior,v_dias_periodo_tc;

	LET v_periodo_anterior = v_periodo_anterior + 1 UNITS DAY;


	--------------------------------------------------------
	--	PREPARA LA TABLA  PARA EDOCTAS
	-------------------------------------------------------

	--INSERT INTO sd_movhisedocta
	--	SELECT a.empresa,			a.secuencia,			   a.fecha_mov,
	--		   a.hora_mov,			a.sucursal,                a.num_credito,
	--		   a.plaza,				a.transacc_suc,			   a.usuario,
	--		   a.monto,             a.codigo_fun,			   a.codigo_ref,
	--		   a.divisa,			a.reversado,			   a.folio_suc,
	--		   a.num_producto,      a.nro_tarjeta,			   a.referencia,
	--		   a.tipo_cambio,		a.monto_dls,			   a.suc_origen,
	--	       a.rfc_comer,			a.referencia23
    --    FROM sd_movhis a, sd_transfun b , bdinteg:si_transacc  c
	--	WHERE a.codigo_fun = b.codigo_fun AND a.codigo_ref  = b.codigo_ref
	--	AND c.numero = b.transacc AND c.se_emite_edocta = "S"
	--	AND fecha_mov >= v_periodo_anterior AND fecha_mov <= pfechahoy
	--	AND reversado <> "S";

   ---EXECUTE PROCEDURE carga_movhis_edocta (pfechahoy) INTO v_cod_ret;

   ---IF v_cod_ret<> "000" THEN
         ---RETURN v_cod_ret;
   ---END IF;

	-- Se agrega validacion para indicar que se haya hecho la muestra para la fecha de corte actual antes de generar los estados de cuenta. RQM 06 143
	/*SELECT LIMIT 1 num_credito
	INTO cNumCredito
	FROM bdicred:"informix".sd_muestra_edocta
	WHERE fecha_corte=pfechahoy;*/

	--IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
	--------------------------------------------------------
	    --  SE GENERAN LOS INSERTOS FIJOS PARA CUENTAS CON 1 Y 5 PAGOS VENCIDOS
		-------------------------------------------------------
		/*
		EXECUTE PROCEDURE bdicred:"informix".sp_activa_insertos_fijos
						(
						pempresa,
						pfechahoy
						) INTO v_cod_ret;

	   IF v_cod_ret<> "00000" THEN
	         RETURN v_cod_ret;
	   END IF;
		*/-- FMJ InActiva insertos de Moras para ECTDC
		-------------------------------------------------------
	        --SE CORRE ACTUALIZACION DE ESTADISTICAS
	        ------------------------------------------------------
		--	UPDATE STATISTICS HIGH FOR TABLE sd_movhisedocta;
		--	UPDATE STATISTICS MEDIUM FOR TABLE sd_movhisedocta;
		-------------------------------------------------------
		--SE ARREGLAN TRANSACCIONES
		------------------------------------------------------
		CALL bdicred:"informix".ARR_MOVHIS(pfechahoy);
		----------------------------------------------------------
		--SE ACTULIZAN LOS REGISTROS QUE RESULTEN DE LA CONSULTA
		----------------------------------------------------------
		--SET DEBUG FILE TO "/informix/edocta.out";
		--TRACE ON;
	--------------------------------------------------------
		--	GENERACION ENCABEZADO EDO CUENTA
		--------------------------------------------------------
	  	LET v_id_registro = "000";
		--SET DEBUG FILE TO "/respaldosbd/Malena/procesos.out";
		--TRACE ON;
	  	IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_encabezado_edocta
	  				  WHERE fecha_emision = pfechahoy
	  				  AND num_credito = v_id_registro) THEN

	 		INSERT INTO bdicred:"informix".sd_encabezado_edocta
				(
	     		fecha_emision,		num_credito, 			numcte,
	     		num_tarjeta, 		nombre_cte,				direccion_cn,
				direccion_col,		direccion_del,			edo_cd,
			 	sucursal_nombre,	sucursal_gerente, 	 	sucursal_tel,
			 	fecha_corte,		rfc,			 	 	cl_cobra,
			 	CP,					ruta,					confirmacion,
				num_region, 		num_ciudad_banco, 		num_ciudad_coppel,
				ec_edocta
				)
	  		VALUES
	  			(
				 pfechahoy,			v_id_registro,			"0",
	  		 	 "0",				"0",					"0",
	  			 "0",				"0",					"0",
	  			 "0",				"0",			 		"0",
	  			 pfechahoy,			"0",			 		"0",
	  			 "0",				"0",					"",
				 "0",				"0",					"0",
				 "0"
				);
	  	END IF
	  	LET v_id_registro = "100";
	 	IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_encabezado_edocta
	  		      WHERE fecha_emision = pfechahoy
	  		      AND num_credito = v_id_registro) THEN

	     	 INSERT INTO bdicred:"informix".sd_encabezado_edocta
				(
	     		fecha_emision,		num_credito, 			numcte,
	     		num_tarjeta, 		nombre_cte,				direccion_cn,
			 	direccion_col,		direccion_del,			edo_cd,
		 	 	sucursal_nombre,	sucursal_gerente, 	 	sucursal_tel,
		 	 	fecha_corte,		rfc,	 	 			cl_cobra,
		 	 	CP,					ruta,					confirmacion,
				num_region, 		num_ciudad_banco, 		num_ciudad_coppel,
				ec_edocta
				)
	  		VALUES  (
				 pfechahoy,			v_id_registro,			"0",
	  		 	 "0",				"0",					"0",
	  			 "0",				"0",					"0",
	  			 "0",				"0",			 		"0",
	  			 pfechahoy,			"0",			 		"0",
	  			 "0",				"0",					"",
				 "0",				"0",					"0",
				 "0"
				);
	 	 END IF
		--------------------------------------------------------
		--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
		--------------------------------------------------------
		LET v_id_registro = "200";
	  	IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_encabezado2_edocta
	  		      WHERE fecha_emision = pfechahoy
	  		      AND num_credito = v_id_registro) THEN


			INSERT INTO bdicred:"informix".sd_encabezado2_edocta
				(
				fecha_emision,		         num_credito,			    capital_tc,
				interes_tc,			         iva_interes_tc,			capital_ven_tc,
				interes_ven_tc,		         iva_interes_ven_tc,		moratorios_tc,
				iva_moratorios_tc,	         sdo_pagar,				    interes_pago_total_tc,
				limite_tc,			         sdo_disponible,			periodo_tc_ini,
				periodo_tc_fin,		         pago_antes_de,			    fecha_corte,
				dias_periodo_tc,	         usted_debia,			    menos_abonos,
				mas_compras,		         sus_comisiones,			mas_disp_efectivo,
				mas_intereses,		         mas_iva,				    mas_rendimientos,
				sdo_debe,			         menos_o_abonos,			mas_o_cargos,
				usted_debe,			
				comisiones_iva,              intereses_iva,             intereses_pag,
				saldo_menos_pag,             compras_disp,			    base_iva,	
				descuento,			         subtotal,				    total,
                pagomin_msi,                 val_base_cfdi,			    iva_intereses_reales_cfdi,
                intereses_reales_cfdi,       mtomensgral_pagosfijos,    iva_cfdi,
                term_pagomin_uno,            pago_int_uno,              pagomin_dos_plazos,
                term_pagomin_dos,			 pago_int_dos,	            pagomin_cinco_plazos,
				term_pagomin_cinco,          pago_int_cinco,            iva_inter_comi,
				sdo_deudor_total,            lim_disp_efectivo,         lim_disp_transferencia,
				sdo_cargo_regular,           sdo_cargo_meses,           inter_comi,
				intereses_pag_12m,           comisiones_pag_12m,        anualidad_pag_12m,
				dist_carg_dif_msi,           dist_carg_dif_con_int
				)
			VALUES (
				pfechahoy,			v_id_registro,			0,
				0,					0,						0,
				0,					0,						0,
				0,					0,						0,
				0,					0,						pfechahoy,
				pfechahoy,			pfechahoy,				pfechahoy,
				0,					0,						0,
				0,					0,						0,
				0,					0,						0,
				0,					0,						0,
				0,					
				0,					0,						0,
				0,					0,						0,	
				0,					0,						0,
				0,					0,						0,
                0,					0,						0,
                "0",				"0",					"0",
                "0",				"0",					"0",
                "0",				"0",					0,
				0,					0,						0,
				0,					0,						0,
				0,					0,						0,
				0,					0
				); 

		END IF;
		
		--------------------------------------------------------
		--    VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
		--------------------------------------------------------
		LET v_id_registro = "201";
		IF NOT EXISTS(SELECT * FROM sd_sdo_int_periodo_edc
				  WHERE fecha_emision = pfechahoy
				  AND num_credito = v_id_registro) THEN


			INSERT INTO sd_sdo_int_periodo_edc
				(
				fecha_emision,                  num_credito,                    descripcion,
				sdo_base,	                    dias_periodo,                   tasa_inter_aplicable,
				monto_interes,                  tipo_proceso
				)
			VALUES (
				pfechahoy,            			trim(v_id_registro),    		"",
				"",                    			"",                        		"",
				"",								"");

		END IF;
		--------------------------------------------------------
		--	VARIABLES GENERACION DETALLE EDO CUENTA
		--------------------------------------------------------
		LET v_id_registro = "300";
		IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_detalle_edocta
			      WHERE fecha_emision = pfechahoy
			      AND num_credito = v_id_registro) THEN

			INSERT INTO sd_detalle_edocta
				(
				fecha_emision, 		num_credito, 			secuencia,
				fecha_mov, 			concepto, 				cargos,
				abonos, 			nlinea
				)
			VALUES
	         	(
	         	pfechahoy,			v_id_registro,			"0",
	         	"0", 				"0", 					"0",
				"0", 				"0"
	         	);

		END IF;
		--------------------------------------------------------
		--	VARIABLES GENERACION DETALLE EDO CUENTA MSI
		--------------------------------------------------------
		LET v_id_registro = "301";
		IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_detalle_msi_edocta
				  WHERE fecha_emision = pfechahoy
				  AND num_credito = v_id_registro) THEN

			INSERT INTO sd_detalle_msi_edocta
				(
				fecha_emision,		folio_movto,	numcte,				num_credito,	num_tarjeta,
				num_sol_prestamo,	num_promo,		fecha_compra,		comercio,		descripcion,
				numero_cuotas,		plazo,			saldo_total_compra,	msipagomin,	saldo_total_deudor,
				diasmes,			secuencia
				)
			VALUES
				(
				pfechahoy,			"0",			"0",				v_id_registro,	"0",
				"0", 				0, 				DATE(1),			"",				"",
				0, 					0,				0,					0,				0,
				0,					0
				);

		END IF
		--------------------------------------------------------
		--	COPPEL MAX  -------------
		--------------------------------------------------------
		LET v_id_registro = "302";
		IF NOT EXISTS(SELECT * FROM sd_coppelmax_edc
				  WHERE fecha_emision = pfechahoy
				  AND num_credito = v_id_registro) THEN

			INSERT INTO sd_coppelmax_edc
				(
				fecha_emision, 		num_credito, 			sdo_inicio_elect,
				dro_elect_utilizado, 	dro_elect_vencido, 		dro_elect_obt,
				dro_elect_x_venc, 	sdo_fin_dro_elect,      equivale_pesos
				)
			VALUES
				(
				pfechahoy,			v_id_registro,			"0",
				"0", 				"0", 					"0",
				"0", 				"0",                    "0"
				);

		END IF;
		--------------------------------------------------------
		--	DETALLE DE MOVIMIENTO DE LAS TARJETAS ADICIONALES
		--------------------------------------------------------
		
		LET v_id_registro = "303";
		IF NOT EXISTS(SELECT * FROM sd_detalle_edocta
				  WHERE fecha_emision = pfechahoy
				  AND num_credito = v_id_registro) THEN

			INSERT INTO sd_detalle_edocta
				(
				fecha_emision, 		num_credito, 			secuencia,
				fecha_mov, 			concepto, 				cargos,
				abonos, 			nlinea
				)
			VALUES
				(
				pfechahoy,			v_id_registro,			"0",
				"0", 				"0", 					"0",
				"0", 				"0"
				);

		END IF
		--------------------------------------------------------
		--	VARIABLES GENERACION DE LINEAS ADICIONALES EDC
		--------------------------------------------------------
		LET v_id_registro = "304";
		IF NOT EXISTS(SELECT * FROM sd_lineas_adicionales_edc
				  WHERE fecha_emision = pfechahoy
				  AND num_credito = v_id_registro) THEN

			INSERT INTO sd_lineas_adicionales_edc
				(
				fecha_emision,		num_credito,	        fecha_oper_adi,	    descripcion_Desc_adi,	 monto_orig_adi,
				saldo_pend_adi,	    intereses_peri_adi,		iva_peri_adi,		pago_requ_adi,		     numero_pago_adi,
				tasa_apli_adi,		credito_adic_adi,		fecha_adic_adi
				)
			VALUES
				(
				pfechahoy,			v_id_registro,			DATE(1),			   "",	                  0,
				0, 				    0, 				        0,			            0,				      0,
				0, 					0,				        DATE(1)
									
				);

		END IF;
		--------------------------------------------------------
		--	VARIABLES GENERACION ACLARACIONES EDO CUENTA
		--------------------------------------------------------
		LET v_id_registro = "400";
		IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_aclaraciones_edocta
			      WHERE fecha_emision = pfechahoy
			      AND num_credito = v_id_registro) THEN


			INSERT INTO bdicred:"informix".sd_aclaraciones_edocta
				(
				fecha_emision, 			num_credito, 		secuencia,
				nlinea,					fecha_aclara, 		folio,
	            fecha_movimiento,       descripcion,    	importe
				)
			VALUES
	         	(
	         	pfechahoy,				v_id_registro,		"0",
	         	"0",					pfechahoy, 			"",
	            "",                            "",         	0
	         	);

		END IF
		--------------------------------------------------------
		--	VARIABLES GENERACION MENSAJES EDO CUENTA
		--------------------------------------------------------
		LET v_id_registro = "500";
		IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_mensajes_edocta
			      WHERE fecha_emision = pfechahoy
			      AND num_credito = v_id_registro) THEN

			INSERT INTO bdicred:"informix".sd_mensajes_edocta
				(
				fecha_emision, 			num_credito, 		secuencia,
				nlinea,					si_paga, 			mensajes,
				meses_liq
				)
			VALUES
	         	(
	         	pfechahoy,				v_id_registro,		"0",
	         	"0",					0, 					"",
				0
	         	);

		END IF
		--------------------------------------------------------
		--	VARIABLES GENERACION PIE EDO CUENTA
		--------------------------------------------------------
	  	LET v_id_registro = "600";
		IF NOT EXISTS(SELECT num_credito FROM bdicred:"informix".sd_pie_edocta
		  	      WHERE fecha_emision = pfechahoy
		  	      AND num_credito = v_id_registro) THEN

			INSERT INTO bdicred:"informix".sd_pie_edocta
				(
				fecha_emision,			num_credito,		tasa_mensual,
				tasa_anual, 			cat, 				saldo_promedio,
				dias_periodo
				)
			VALUES  (
				pfechahoy, 				v_id_registro, 		"0",
				"0", 					"0", 				"0",
				"0"
				);
		  END IF
      --------------------------------------------------------
			--	GENERA ENCABEZADO DE PAGOS DIFERIDOS
			--------------------------------------------------------
			LET v_id_registro = "900";
			IF NOT EXISTS(SELECT * FROM sd_detalle_dif_edocta
					  WHERE fecha_emision = pfechahoy
					  AND num_credito = v_id_registro) THEN

				INSERT INTO sd_detalle_dif_edocta
					(
					fecha_emision, 			num_credito, 		num_promocion,
					num_cred_credsol,		folio_suc, 			plazo,
					diasmes,				fecha,				tasa,
					saldo_pendiente,		prox_fecha_pago,	concepto,
					monto_prox_pago,		numero_cuotas,		secuencia,
					nlinea
					)
				VALUES
					(
					pfechahoy,				v_id_registro,		"0",
					"0",					0, 					"0",
					0,						pfechahoy,			0,
					0,						pfechahoy,			'',
					0,						'0/0',				0,
					0
					);
			END IF
		--------------------------------------------------------
		--	GENERA VARIABLES GLOBALES
		-------------------------------------------------------
	    ----VALOR DEL CAT
		SELECT valor INTO v_cat
		FROM bdicred:"informix".sd_param
		WHERE empresa = pempresa
		AND cod_param = '035';

		IF v_cat IS NULL THEN
			LET v_cat = 0.0;
		END IF
		
			SELECT valor INTO v_cat2
			FROM sd_param
			WHERE empresa = pempresa
			AND cod_param = '091'; 

			IF v_cat2 IS NULL THEN
				LET v_cat2 = 0.0;
			END IF
			
				--AAME RQM 10 679 Se contempla nuevo parametro para el valor de CAT de TDC ORO
				SELECT valor INTO v_cat3
				FROM sd_param
				WHERE empresa = pempresa
				AND cod_param = '093'; 

				IF v_cat3 IS NULL THEN
					LET v_cat3 = 0.0;
				END IF;
	    
		-----MENSAJES IMPORTANTES DEL ESTADO DE CUENTA 
		CREATE TEMP TABLE mensajes_imp(
				clave     serial,
				secuencia integer,
				mensaje   char(400));
			
			LET idTxt="";
			LET v_texto="";
			LET v_clave=1;
			LET v_secuencia=1;
			FOREACH WITH HOLD

					SELECT tipo_mens,mensajes INTO idTxt,v_texto
					FROM bdicred:sd_msjs_globales_edc where num_producto ='6001' and tipo_mens = 'MI' order by clave
					 
					INSERT INTO mensajes_imp values (v_clave,v_secuencia,v_texto);


				LET v_clave = v_clave + 1;
			END FOREACH;
			
			-----MENSAJES ADICIONALES DEL ESTADO DE CUENTA 
			BEGIN; DELETE FROM "informix".sd_mensajes_mensual_edocta WHERE fecha_emision = pfechahoy; COMMIT;
			LET v_clave=1;
			FOREACH WITH HOLD
				SELECT tipo_mens,mensajes INTO idTxt,v_texto
				FROM bdicred:sd_msjs_globales_edc where num_producto ='6001' and tipo_mens = 'MA' order by clave
				 
				LET v_secuencia=1;
				--LET v_corta_linea_mensaje = 145;
				INSERT INTO bdicred:"informix".sd_mensajes_mensual_edocta(fecha_emision,secuencia,nlinea,mensaje,tipo_mens)
										VALUES(pfechahoy,v_clave,v_secuencia,v_texto,idTxt);

				LET v_clave = v_clave + 1;
			END FOREACH;
			
			-----ATENCION DE QUEJAS DEL ESTADO DE CUENTA 
			LET v_clave=1;
			LET idTxt="";
			LET v_texto="";
			LET v_secuencia=1;
			FOREACH WITH HOLD
				SELECT tipo_mens,mensajes INTO idTxt,v_texto
				FROM bdicred:sd_msjs_globales_edc where num_producto ='6001' and tipo_mens = 'AQ' order by clave
				
				INSERT INTO bdicred:"informix".sd_mensajes_mensual_edocta(fecha_emision,secuencia,nlinea,mensaje,tipo_mens)
										VALUES(pfechahoy,v_clave,v_secuencia,v_texto,idTxt);
				 
				LET v_clave = v_clave + 1;

			END FOREACH;
			
			-- ELIMINA INFORMACION DE MENSAJES POR CADA EJECUCION
			BEGIN; TRUNCATE TABLE "informix".sd_notas_aclara_edc DROP STORAGE; COMMIT;
			
			SELECT count(*) INTO total_msj
			FROM bdicred:sd_msjs_globales_edc where num_producto ='6001' and tipo_mens = 'NA';
			
			-----NOTAS ACLARATORIAS DEL ESTADO DE CUENTA 
			CREATE TEMP TABLE notas(
				clave     serial,
				secuencia integer,
				inciso	  char(1),
				mensaje   char(666)
			);

			--LET v_clave=1;
			LET v_secuencia=1;
			LET v_contador = 0;
			FOREACH WITH HOLD
				SELECT mensajes INTO vTextoNotas
				FROM bdicred:sd_msjs_globales_edc where num_producto ='6001' and tipo_mens = 'NA' order by clave

				LET v_inciso = CHR(ASCII('a') + v_contador);
					INSERT INTO notas (	secuencia, 	inciso, 	mensaje) 
								VALUES (v_secuencia,v_inciso,vTextoNotas);
		
				LET v_contador = v_contador + 1;
				IF v_contador > total_msj THEN 
					EXIT FOREACH;
				END IF;
			END FOREACH;

			INSERT INTO bdicred:"informix".sd_notas_aclara_edc
			SELECT clave, secuencia, inciso, mensaje FROM notas;
			
			-----MENSAJES DE GLOSARIO DEL ESTADO DE CUENTA
			BEGIN; TRUNCATE TABLE "informix".sd_glosario_edc DROP STORAGE; COMMIT;
			CREATE TEMP TABLE mensajes_glos(
				clave     INTEGER,
				secuencia INTEGER,
				termino CHAR(125),
				significado CHAR(475)
			);
			
			LET vClaveGlos=1;
			LET vSecGlos=1;
			FOREACH WITH HOLD
				SELECT termino,significado INTO vTerminoG,vTextoG
				 FROM bdicred:sd_glosario_edcpte order by clave

				insert into mensajes_glos values (vClaveGlos,vSecGlos,vTerminoG,vTextoG);
				 

				LET vClaveGlos = vClaveGlos + 1;
			END FOREACH;
			
			INSERT INTO bdicred:"informix".sd_glosario_edc
			SELECT clave, secuencia, termino, significado FROM mensajes_glos;

	 	--------------------------------------------------------
		--	INICIA CON LA GENARACION DE MUESTRAS
		-------------------------------------------------------

	 	FOREACH SELECT a.empresa,a.num_credito
	 			INTO v_empresa,v_num_credito
	 			FROM bdicred:"informix".sd_maesdoshist a, bdicred:"informix".sd_muestra_edocta b
	        	WHERE a.fecha = pfechahoy
				AND b.fecha_corte= pfechahoy
	        	AND a.empresa = pempresa
	            AND a.num_credito = b.num_credito
	        	AND a.num_credito NOT IN
	        	(SELECT num_credito FROM bdicred:"informix".sd_encabezado_edocta
	        	WHERE fecha_emision = pfechahoy)
				
				
			EXECUTE PROCEDURE bdicred:"informix".sp_edocta_msi_detalle
					('001', pfechahoy, v_num_credito
					) INTO v_cod_ret;


			EXECUTE PROCEDURE bdicred:"informix".generaestadosdecuenta
						(
						v_empresa,
						v_num_credito,
						pfechahoy
						) INTO v_cod_ret;

	      	IF v_cod_ret <> "000" THEN

	      		SELECT descripcion  INTO v_descripcion
	      		FROM bdinteg:"informix".si_codret
	      		WHERE codigo_retorno = v_cod_ret
	      		AND sistema  ="06";

	      		INSERT INTO bdicred:"informix".sd_valedocta
	      			(
	      			empresa,		num_credito,		cod_ret,
	      			descripcion,	fecha_proc,			tipo
	      			)
	      		VALUES
	      			(
	      			v_empresa,		v_num_credito,		v_cod_ret,
	      			v_descripcion,	pfechahoy,			"E"
	      			);
					
				DELETE FROM sd_encabezado_edocta where fecha_emision =   pfechahoy and num_credito =v_num_credito;
				DELETE FROM sd_encabezado2_edocta where fecha_emision =   pfechahoy and num_credito =v_num_credito;
				DELETE FROM sd_pie_edocta where fecha_emision =   pfechahoy and num_credito =v_num_credito;
				DELETE FROM sd_aclaraciones_edocta where fecha_emision =   pfechahoy and num_credito =v_num_credito;
				DELETE FROM sd_detalle_edocta where fecha_emision =   pfechahoy and num_credito =v_num_credito;
				DELETE FROM sd_mensajes_edocta where fecha_emision =   pfechahoy and num_credito =v_num_credito;
				DELETE FROM sd_sdo_int_periodo_edc where fecha_emision =   pfechahoy and num_credito =v_num_credito;
				
			END IF;
			
	 	END FOREACH;
        
			DROP TABLE IF EXISTS mensajes_imp;
			DROP TABLE IF EXISTS notas;
			DROP TABLE IF EXISTS mensajes_glos;
		RETURN "000";

		--END IF;
--	ELSE
--		RETURN "001"; -- Se agrega codigo de retorno que indica que no se ha hecho aun la muestra para la fecha de corte actual RQM 06 143
--	END IF;

END;
END PROCEDURE
DOCUMENT
'CAMBIO: Se modifica procedimiento para agregar validacion para indicar que se haya hecho la muestra para la fecha de corte actual antes de generar los estados de cuenta.',
'MODIFICO : Maria Elena Angulo Aispuro',
'FECHA : 13/JULIO/2011',
'BD: BDICRED',
'VERSION:20110713.1645';

CREATE PROCEDURE "informix".genmov_tc(
   p_empresa                VARCHAR(3),
   p_num_credito            VARCHAR(20),
   p_num_producto           VARCHAR(4),
   p_fecha_hoy              DATE,
   p_monto                  MONEY(14,2),
   p_foliosuc               VARCHAR(16),
   p_sucursal               VARCHAR(4),
   p_divisa                 VARCHAR(2),
   p_transacc_suc           VARCHAR(4),
   p_tarjeta                VARCHAR(20),
   p_referencia             VARCHAR(40),
   p_tipo_cambio            DECIMAL(14,6),
   p_monto_dls              DECIMAL(14,2),
   p_usuario                CHAR(8),
   p_sucorigen		    CHAR(4),
   p_rfc_comer	  	    VARCHAR(20),
   p_referencia23	    VARCHAR(23))

RETURNING VARCHAR(10), VARCHAR(80);

DEFINE   p_cod_ret       VARCHAR(10);
DEFINE   p_mensaje       VARCHAR(80);

DEFINE   v_plaza         VARCHAR(3);
DEFINE   v_hora          DATETIME HOUR TO FRACTION(3);
DEFINE   vm_secuencia    INTEGER;
DEFINE   v_reversado     VARCHAR(1);
DEFINE   v_usuario       VARCHAR(8);

DEFINE   v_num_producto  VARCHAR(4);
DEFINE   v_codigo_ref    INTEGER;
DEFINE   v_codigo_fun    VARCHAR(3);
DEFINE   v_fecha_hoy     DATE;
DEFINE   v_monto         DECIMAL(18,2);
DEFINE   v_foliosuc      VARCHAR(16);
DEFINE   v_sucursal      VARCHAR(4);
DEFINE   v_divisa        VARCHAR(2);
DEFINE   v_transacc_suc  VARCHAR(4);
DEFINE   vCodFun         CHAR(3);
DEFINE   vCodRef         SMALLINT;
define   v_refpaso       varchar(63);

DEFINE SQL_ERR     INTEGER;
DEFINE ISAM_ERR    INTEGER;
DEFINE ERROR_INFO  VARCHAR(80);
DEFINE vcadena     INTEGER;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET  = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

   LET P_COD_RET      = '000';
   LET P_MENSAJE      = 'PROCESO EXITOSO';
   LET v_num_producto =  p_num_producto ;
   LET v_fecha_hoy    =  p_fecha_hoy    ;
   LET v_monto        =  p_monto        ;
   LET v_foliosuc     =  p_foliosuc     ;
   LET v_sucursal     =  p_sucursal     ;
   LET v_divisa       =  p_divisa       ;
   LET v_transacc_suc =  p_transacc_suc ;
   let v_refpaso      = '';

   IF (p_transacc_suc IS NULL) THEN
      LET p_cod_ret = '110';
      LET P_MENSAJE = 'ERROR';
      RETURN P_COD_RET, P_MENSAJE;
   ELSE
      SELECT codigo_fun, codigo_ref
	INTO vCodFun, vCodRef
       FROM sd_transfun
      WHERE empresa = p_empresa
	AND transacc = p_transacc_suc;

      IF vCodFun IS NULL THEN
      	LET p_cod_ret = '110';
      	LET P_MENSAJE = 'ERROR';
      	RETURN P_COD_RET, P_MENSAJE;
      END IF
   END IF;

   IF (v_fecha_hoy IS NULL) THEN
      SELECT fecha_hoy
      INTO   v_fecha_hoy
      FROM   sd_fechas;
   END IF;
   IF (v_monto IS NULL) THEN
      LET v_monto = 0;
   END IF;
   IF (v_divisa IS NULL) THEN
      LET v_divisa = '00';
   END IF;
   IF (v_num_producto IS NULL) THEN
      LET v_num_producto = '    ';
   END IF;

   IF (v_foliosuc IS NULL) THEN
      LET p_cod_ret = '110';
      LET P_MENSAJE = 'ERROR';
      RETURN P_COD_RET, P_MENSAJE;
   END IF;

   LET p_cod_ret    = '000';
   LET P_MENSAJE    = 'PROCESO EXITOSO';
   LET v_hora       = EXTEND(CURRENT,HOUR TO fraction(3));

   LET v_reversado  = 'N';
--   v_usuario    := USER;


   LET vcadena = 0;

--   let vcadena = length(p_foliosuc) - 8;
--   LET v_usuario    = substr(p_foliosuc,1,vcadena);

--   LET v_usuario    = substr(v_foliosuc,1,8);

   --############################################################
   --####  GENERACION DE MOVIMIENTOS Y DETALLE CONTABLE     #####
   --############################################################

   IF p_referencia IS NULL OR p_referencia = " " THEN
	SELECT nvl(abreviatura,'') INTO p_referencia
	  FROM sd_transfun a, bdinteg:si_transacc b
	 WHERE a.empresa = p_empresa
	   AND a.codigo_fun = vCodFun
	   AND a.codigo_ref = vCodRef
	   AND b.empresa = a.empresa
	   AND b.numero = a.transacc
	   AND b.sistema = "06";
   END IF

   if (length(p_referencia) > 1) then
      LET v_refpaso = trim(p_foliosuc || " " || trim(p_referencia));
   else
      LET v_refpaso = trim(p_foliosuc);
   end if;

-- En caso de no tener referencia23 utilzia espacios para guardar referencia adicional
   if (trim(nvl(p_referencia23,'')) = '' and length(trim(v_refpaso)) > 40) then
      LET p_referencia23 = substr(trim(v_refpaso),41);
   end if;

   let p_referencia = trim(v_refpaso);

-- limpia referencia en IVA
   if (vCodFun = '340') then
      LET p_referencia = '';
   end if;

   SELECT plaza
   INTO   v_plaza
   FROM   bdinteg:si_sucursales
   WHERE  empresa  = p_empresa
   AND    sucursal = v_sucursal;

   IF V_PLAZA IS NULL OR V_PLAZA = '' THEN
      LET P_COD_RET = '00100';
      LET P_MENSAJE = 'LA INFORMACION PLAZA/SUCURSAL DEL CREDITO ES INCORRECTA';
      RETURN P_COD_RET, P_MENSAJE;
   END IF;

   INSERT INTO sd_movdia (
               EMPRESA        ,
               FECHA_MOV      ,
               HORA_MOV       ,
               SUCURSAL       ,
               NUM_CREDITO    ,
               PLAZA          ,
               TRANSACC_SUC   ,
               USUARIO        ,
               MONTO          ,
               CODIGO_FUN     ,
               CODIGO_REF     ,
               DIVISA         ,
               REVERSADO      ,
               FOLIO_SUC      ,
               NUM_PRODUCTO   ,
	       NRO_TARJETA    ,
	       REFERENCIA     ,
               TIPO_CAMBIO    ,
	       MONTO_DLS      ,
	       SUC_ORIGEN     ,
	       RFC_COMER      ,
	       REFERENCIA23   )
      VALUES ( p_empresa,
               v_fecha_hoy,
               current,
               v_sucursal,
               p_num_credito,
               v_plaza,
               v_transacc_suc,
               p_usuario,
               v_monto,
               vCodFun,
               vCodRef,
               v_divisa,
               v_reversado,
               v_foliosuc,
               v_num_producto,
	       p_tarjeta,
	       p_referencia,
	       p_tipo_cambio,
	       p_monto_dls,
               p_sucorigen,
	       p_rfc_comer,
	       p_referencia23);

   RETURN P_COD_RET, P_MENSAJE;

END
END PROCEDURE
DOCUMENT
'Esta funcion realiza el Registro de los Movimientos generados por T.C.',
'AUTOR : Antonio Ruiz Martinez',
'FECHA : 29/12/2006',
'BD : bdicred ',
'CLIENTE : COPPEL';

create procedure "informix".cargo_ref_cel(pnum_tarjeta  char(16),
                                       psucursal    char(4),
                                       pusuario     char(8),
                                       ptransacc    char(4),
                                       ptransuc     char(4),
                                       pfolsuc      char(16),
                                       pcuenta      char(20),
                                       pcheque      integer,
                                       pmtocompra   money(14,2),
                                       pmontoefe    money(14,2),
                                       ptransefe    char(4),
                                       pfolioefe    char(16),
                                       pdivisa      char(2),
                                       preferencia  char(40),
                                       psucursalcom char(4),
                                       pusuariocom  char(8),
                                       ptrancencom  char(4),
                                       ptransuccom  char(4),
                                       pfolsuccom   char(16),
                                       pcuentacom   char(20),
                                       pchequecom   integer,
                                       pmontocom    money(14,2),
                                       pdivisacom   char(2),
                                       prefercom    char(40),
                                       pbanderacom  char(1),
                                       ptrancomefe  char(4),
                                       ptrascomefe  char(4),
                                       pfolcomefe   char(16),
                                       pchequeefe   integer,
                                       pmtocomefe   money(14,2),
                                       pdivcomefe   char(2),
                                       prefcomefe   char(40))

       returning char(5),char(4),date,money(14,2),money(14,2),
                 char(5),char(4),date,money(14,2),money(14,2);

define vsqlerr int;
define vcodret,vcodret1,vcodretcom char(5);
define vtranret1,vtranret,vtransacc char(4);
define vtiporef char(1);
define vfechoy date;
define vsdodisp money(14,2);
define vcompend money(14,2);
define vmontoret,vtotcom money(14,2);
define vempresa char(3);
define vejecargo char(1);
define vconreg smallint;
define vcuenta char(20);
define vtotiva money(14,2);
define vtasaiva decimal(9,3);
define vivacom money(14,2);
define vtotret money(14,2);
define vsuccta char(4);
define vtraniva char(4);
define vfecapli date;

define vmtoapli money(14,2);


-- set debug file to "/tmp/cargo_ref_cel.out";
-- trace on;

set lock mode to wait 2;
begin
   on exception set vsqlerr
      if vsqlerr <> 0  then
         let vcodret = vsqlerr;
          ROLLBACK WORK; 
         return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
                vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
      end if;
   end exception;

   --set isolation to cursor stability;

   BEGIN WORK;

   let vcodret = "000";
   let vtranret = " ";
   let vsdodisp = 0;
   let vmontoret = 0;
   let vcodretcom = "000";
   let vtotcom = 0;
   let psucursal = "9"||trim(psucursal);
   let psucursalcom = "9"||trim(psucursalcom);

   select empresa into vempresa
      from bdinteg:si_ejecut
      where ejecutivo = pusuario;

   select fecha_hoy into vfechoy
      from sc_fechas
      where empresa = vempresa;

   let vmontoret = pmtocompra+pmontoefe;
   let vtotcom = pmontocom + pmtocomefe;
   let vfecapli = vfechoy;
   select cuenta into vcuenta
      from sc_tarjeta
      where empresa = vempresa and
            num_tarjeta = pnum_tarjeta;
   if vcuenta is null then
      let vcodret = "100";
      ROLLBACK WORK; 
      return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
             vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
   end if
   select sucursal,sdo_actual-sdo_retenido-sdo_cong
      into vsuccta, vsdodisp
      from sc_maechq
      where empresa = vempresa and cuenta = vcuenta;
   select iva into vtasaiva
      from bdinteg:si_sucursales
      where empresa = vempresa and sucursal = vsuccta;
   if vtasaiva is null then
      let vtasaiva = 0;
   end if
   let vtotiva = vtotcom * vtasaiva;
   let vtotret = pmtocompra + pmontoefe + vtotcom + vtotiva;
   if vsdodisp < vtotret then
      let vcodret = "400";
      ROLLBACK WORK; 
      return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
             vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
   end if

   if pmtocompra > 0 then
      call cargo_ref_td(vempresa,psucursal,pusuario,ptransacc,ptransuc,
                   pfolsuc,vcuenta,pcheque,pmtocompra,pdivisa,preferencia,
                   pnum_tarjeta,"")
           returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
      if vcodret <> "000" then
         ROLLBACK WORK; 
   {      call reversiontd(vempresa,psucursal,pusuario,pfolsuc,"A",
                          vcuenta,ptransacc)
              returning vcodret1;}
         return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
                vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
      end if
   end if

   if pmontoefe > 0 then
      call cargo_ref_td(vempresa,psucursal,pusuario,ptransefe,ptransuc,
                      pfolioefe,vcuenta,pcheque,pmontoefe,pdivisa,preferencia,
                      pnum_tarjeta,"")
           returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
      if vcodret <> "000" then
         ROLLBACK WORK; 
         {
         call reversiontd(vempresa,psucursal,pusuario,pfolsuc,"A",
                          vcuenta,ptransacc)
              returning vcodret1;
         
         call reversiontd(vempresa,psucursal,pusuario,pfolioefe,"A",
                          vcuenta,ptransefe)
              returning vcodret1;}
         return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
                vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
      end if
   end if
   if pmontocom > 0 then
      call cargo_ref_td(vempresa,psucursal,pusuario,ptrancencom,ptransuccom,
                      pfolsuccom,vcuenta,pchequecom,pmontocom,pdivisacom,
                      prefercom,pnum_tarjeta,"")
           returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
      if vcodret <> "000" then
         ROLLBACK WORK; 
         {
         call reversiontd(vempresa,psucursal,pusuario,pfolsuc,"A",
                        vcuenta,ptransacc)
              returning vcodret1;
         
         call reversiontd(vempresa,psucursal,pusuario,pfolioefe,"A",
                        vcuenta,ptransefe)
              returning vcodret1;
         call reversiontd(vempresa,psucursal,pusuario,pfolsuccom,"A",
                        vcuenta,ptrancencom)
              returning vcodret1;}
         return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
                vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
      else
         select tran_relac into vtraniva
            from bdinteg:si_transacc
            where empresa = vempresa and numero = ptrancencom;
         let vivacom = pmontocom * vtasaiva;
         if vivacom > 0 then
            call cargo_ref_td(vempresa,psucursal,pusuario,vtraniva,"0000",
                     pfolsuccom,vcuenta,pchequecom,vivacom,pdivisacom,
                     prefercom,pnum_tarjeta,"")
                 returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
            if vcodret <> "000" then
               ROLLBACK WORK; 
               {
               call reversiontd(vempresa,psucursal,pusuario,pfolsuc,"A",
                                vcuenta,ptransacc)
                    returning vcodret1;
               
               call reversiontd(vempresa,psucursal,pusuario,pfolioefe,"A",
                                vcuenta,ptransefe)
                    returning vcodret1;
               call reversiontd(vempresa,psucursal,pusuario,pfolsuccom,"A",
                                vcuenta,ptrancencom)
                    returning vcodret1;}
               return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
                      vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
            end if
         end if
      end if
   end if
   if pmtocomefe > 0 then
      call cargo_ref_td(vempresa,psucursal,pusuario,ptrancomefe,
                      ptrancomefe,pfolcomefe,vcuenta,pchequeefe,
                      pmtocomefe,pdivcomefe,prefcomefe,pnum_tarjeta,"")
           returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
      if vcodret <> "000" then
         ROLLBACK WORK; 
         {
         call reversiontd(vempresa,psucursal,pusuario,pfolsuc,"A",
                          vcuenta,ptransacc)
              returning vcodret1;
         
         call reversiontd(vempresa,psucursal,pusuario,pfolioefe,"A",
                          vcuenta,ptransefe)
              returning vcodret1;
         call reversiontd(vempresa,psucursal,pusuario,pfolsuccom,"A",
                          vcuenta,ptrancencom)
              returning vcodret1;
         call reversiontd(vempresa,psucursal,pusuario,pfolcomefe,"A",
                          vcuenta,ptrancomefe)
              returning vcodret1;}
      else
         select tran_relac into vtraniva
            from bdinteg:si_transacc
            where empresa = vempresa and numero = ptrancencom;
         let vivacom = pmtocomefe * vtasaiva;
         if vivacom > 0 then
            call cargo_ref_td(vempresa,psucursal,pusuario,vtraniva,
                      "0000",pfolcomefe,vcuenta,pchequeefe,
                      vivacom,pdivcomefe,prefcomefe,pnum_tarjeta,"")
                 returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
            if vcodret <> "000" then
               ROLLBACK WORK; 
              { 
               call reversiontd(vempresa,psucursal,pusuario,pfolcomefe,"A",
                                vcuenta,ptransacc)
                    returning vcodret1;
               call reversiontd(vempresa,psucursal,pusuario,pfolioefe,"A",
                                vcuenta,ptransefe)
                    returning vcodret1;
               call reversiontd(vempresa,psucursal,pusuario,pfolsuccom,"A",
                                vcuenta,ptrancencom)
                    returning vcodret1;}
               return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
                      vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
            end if
         end if
      end if
   end if
   let vfechoy = vfecapli;
   select sdo_actual-sdo_retenido-sdo_cong into vsdodisp
      from sc_maechq
      where empresa = vempresa and cuenta = vcuenta;
   COMMIT WORK;
   return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
          vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
end
end procedure;