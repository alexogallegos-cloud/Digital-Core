CREATE PROCEDURE "informix".executaedoctageneral_repro(pempresa CHAR(3),pfechahoy DATE) 
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
LET v_corta_linea_mensaje 	= 135;
LET cNumCredito				= "";

---- -SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION COMMITTED READ;

BEGIN


  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_cod_ret = sql_err;

            RETURN v_cod_ret;
        END IF
   END EXCEPTION;


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	--------------------------------------------------------------
	-----EJECUTA PROCESO LLENADO DE TABLA SD_MUESTRA_EDOCTA-------
	--------------------------------------------------------------
--temporal rss
/*	EXECUTE PROCEDURE "informix".executaedoctageneral_muestra('001','01-01-1990')
	INTO v_cod_ret,v_mensajes;
	
	EXECUTE PROCEDURE "informix".sp_edocta_credsol_detalle('001','01-01-1990')
	INTO v_cod_ret;*/
--temporal rss

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
--temporal rss
/*	EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(pfechahoy,-1,DAY(pfechahoy))
	INTO v_cod_ret,v_periodo_anterior,v_dias_periodo_tc;*/
/* (expression)     (expression)     (expression)    
 ---------------  ---------------  --------------- 
 000              20/09/2022       -30*/             

let v_cod_ret='000';
let v_periodo_anterior=mdy('09','20','2022');
let v_dias_periodo_tc=-30;
--temporal rss

 

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
				fecha_emision,		num_credito,			capital_tc,
				interes_tc,			iva_interes_tc,			capital_ven_tc,
				interes_ven_tc,		iva_interes_ven_tc,		moratorios_tc,
				iva_moratorios_tc,	sdo_pagar,				interes_pago_total_tc,
				limite_tc,			sdo_disponible,			periodo_tc_ini,
				periodo_tc_fin,		pago_antes_de,			fecha_corte,
				dias_periodo_tc,	usted_debia,			menos_abonos,
				mas_compras,		sus_comisiones,			mas_disp_efectivo,
				mas_intereses,		mas_iva,				mas_rendimientos,
				sdo_debe,			menos_o_abonos,			mas_o_cargos,
				usted_debe,			mensajes,
				comisiones_iva,     intereses_iva,          intereses_pag,
				saldo_menos_pag,    compras_disp,			base_iva,	
				descuento,			subtotal,				total 		
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
				0,					"",
				0,					0,						0,
				0,					0,						0,	
				0,					0,						0	
				); 

		END IF
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

		END IF
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
				END IF				
	    -----MENSAJES DEL ESTADO DE CUENTA

	        CREATE TEMP TABLE bdicred:mensajes(
	                clave     serial,
	                secuencia integer,
	                mensaje   char(150));




	        LET v_clave=1;
	            FOREACH
	                    SELECT  REPLACE(mensajes,'{0}',TRIM(v_linea_auxiliar::VARCHAR(21))) INTO v_texto
	                     FROM bdicred:"informix".sd_config_mensaje_edocta WHERE clave < 99 AND num_producto = v_num_producto
	                     order by clave

	                     LET v_secuencia=1;

	                FOREACH
	                     EXECUTE PROCEDURE corta_linea(TRIM(v_texto),v_corta_linea_mensaje) INTO v_mensajes, v_corta_retorno
	                     INSERT INTO bdicred:mensajes VALUES (v_clave,v_secuencia,v_mensajes);
	                     LET v_secuencia=v_secuencia+1;
	                END FOREACH;

	                LET v_clave = v_clave + 1;

	            END FOREACH;


	            DELETE bdicred:"informix".sd_mensajes_mensual_edocta WHERE fecha_emision = pfechahoy;

	            INSERT INTO bdicred:"informix".sd_mensajes_mensual_edocta
	            SELECT pfechahoy, clave, secuencia,mensaje FROM bdicred:mensajes WHERE clave <> '2';

	            DELETE FROM bdicred:mensajes WHERE clave <> '2';

	 	--------------------------------------------------------
		--	INICIA CON LA GENARACION DE MUESTRAS
		-------------------------------------------------------

	 	FOREACH SELECT a.empresa,a.num_credito
	 			INTO v_empresa,v_num_credito
	 			FROM bdicred:"informix".sd_maesdoshist a, bdicred:"informix".sd_muestra_edocta b
	        	WHERE a.fecha = pfechahoy
				AND b.fecha_corte= pfechahoy
				--AND b.flag_generacion=1
	        	AND a.empresa = pempresa
	            AND a.num_credito = b.num_credito
	        	AND a.num_credito NOT IN
	        	(SELECT num_credito FROM bdicred:"informix".sd_encabezado_edocta
	        	WHERE fecha_emision = pfechahoy)


			EXECUTE PROCEDURE bdicred:"informix".generaestadosdecuenta_repro
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
			END IF            
	 	END FOREACH;
        
        --execute procedure ugenera_layoutedocuenta_muestras( pempresa, pfechahoy ) into v_cod_ret;

		/*IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			DROP TABLE bdicred:mensajes;
			RETURN "002";  --'Aun no se revisan los estados de cuenta'	RQM 06 143
		ELSE*/
		 	--------------------------------------------------------
			--	GENERA UNO A UNO LOS ESTADOS DE CUENTA
			-------------------------------------------------------
			/* ---Se programa dentro de Ctrl M
			FOREACH SELECT empresa,num_credito
		 			INTO v_empresa,v_num_credito
		 			FROM bdicred:"informix".sd_maesdoshist
		        	WHERE fecha = pfechahoy
		        	AND empresa = pempresa
		        	AND num_credito NOT IN
		        	(SELECT num_credito FROM bdicred:"informix".sd_encabezado_edocta
		        	WHERE fecha_emision = pfechahoy)



				EXECUTE PROCEDURE bdicred:"informix".GeneraEstadosdeCuenta
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

				END IF
		 	END FOREACH;

		    DROP TABLE bdicred:mensajes;

			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_encabezado_edocta;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_encabezado2_edocta;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_detalle_edocta;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_aclaraciones_edocta;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_mensajes_edocta;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_mensajes_mensual_edocta;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_pie_edocta;
			*/
			DROP TABLE bdicred:mensajes;
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

CREATE PROCEDURE "informix".sp_msi_consultmovs_bpi(pEmpresa CHAR(3), pNumCredito CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pRegistro INTEGER)
RETURNING CHAR(5),DATE,CHAR(40),CHAR(60),CHAR(1),MONEY(14,2),MONEY(14,2),CHAR(4),CHAR(1);
		 
--Variables auxiliares
DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cErrorInfo      CHAR(80);
DEFINE vcodret         CHAR(6); 
DEFINE cMensajeRet     CHAR(80);


--Definicion de variables
DEFINE vserial       INTEGER;
DEFINE vfecha        DATE;
DEFINE vRefTotal CHAR(100);
DEFINE cDescripcion     CHAR(60);
DEFINE vnaturaleza   CHAR(1);			
DEFINE vmonto        MONEY(14,2);
DEFINE vReferencia23  CHAR(23);
DEFINE vRfcComer     CHAR(15);
DEFINE vTrans     CHAR(4);
DEFINE vTarjeta   CHAR(20);
DEFINE vTipo         CHAR(1);
DEFINE cFolioSuc		CHAR(16);
DEFINE iNumPago			INTEGER;
DEFINE iPlazo       	INTEGER;
DEFINE vComercio    	VARCHAR(40);
DEFINE vReferencia    CHAR(40);
DEFINE vTerminacion CHAR(4);
DEFINE vSdoDeudorMSI    DECIMAL(14,2);
DEFINE vMotivoCancel    	CHAR(80);
DEFINE dtmFechaCancela DATETIME YEAR TO SECOND;


LET vcodret            	= "000";
LET cMensajeRet        	= "Se realizo la consulta correctamente";
LET vserial = 0;
LET vfecha = '01/01/1900';
LET vRefTotal = "";
LET cDescripcion = " ";
LET vnaturaleza = '';
LET vmonto = 0;
LET vReferencia23 = '';
LET vRfcComer = '';
LET vTrans = '';
LET vTarjeta ='';
LET vTipo ='';
LET cFolioSuc =	"";   
LET iNumPago	= 0;
LET iPlazo = 0;
LET vComercio = "";
LET vReferencia = '';
LET vTerminacion ='';
LET vSdoDeudorMSI = 0;
LET vMotivoCancel = "";
LET dtmFechaCancela = '';


 -- *****************************************************************************************************        
   -- Obejtivo:			Consulta de Movimietos MSI
   -- Creado por:		Roque Heras
   -- Solicitado por:	Gabriela Aguilar
   -- Fecha:			29/04/2022
   -- *****************************************************************************************************
BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr != 0 THEN
		  LET vcodret = iSqlErr;
		  LET cMensajeRet = cErrorInfo;
		  RETURN vcodret, vfecha, vReferencia, cDescripcion, vnaturaleza, vmonto,vSdoDeudorMSI, vTerminacion, vTipo;
	   END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/gaby/ArchivosOut/sp_msi_consultmovs_bpi.out';
	--TRACE ON;
	
	-- Productos permitidos: 
	-- 8900 - MESES SIN INTERESES
	FOREACH
		( 	
			SELECT SKIP pRegistro FIRST 10
				movd.secuencia, movd.fecha_mov, 
				CASE WHEN NVL(TRIM(movd.referencia),'') = '' THEN tfun.transacc ELSE TRIM(movd.referencia) END CASE,
				tfun.descripcion, tcc.naturaleza, movd.monto, movd.referencia23, movd.rfc_comer, tcc.numero, '' as num_tarjeta, 'S' as tipo_tarjeta, movd.folio_suc, 
				ac.num_pago as numpago, mae.plazo, imov.infreceptor, mccm.fecha_cancela, mccm.motivo_de_cancelacion
			INTO vserial,vfecha,vRefTotal,cDescripcion,vnaturaleza,vmonto, vReferencia23, vRfcComer, vTrans, vTarjeta, vTipo, cFolioSuc, 
			iNumPago, iPlazo, vComercio, dtmFechaCancela, vMotivoCancel
			FROM bdicred:sd_promocion_credito pm
			INNER JOIN bdicred:sd_maecredcrd mae ON (pm.num_sol_prestamo = mae.num_credito)
			INNER JOIN bdicred:sd_movdiacrd movd ON (movd.num_credito = pm.num_sol_prestamo)
				--AND ((movd.codigo_fun = '002' AND movd.codigo_ref = 128) OR (movd.codigo_fun = '041' AND movd.codigo_ref = 1))) 
			INNER JOIN bdicred:sd_transfun tfun ON (tfun.codigo_fun = movd.codigo_fun AND tfun.codigo_ref = movd.codigo_ref)
			INNER JOIN bdinteg:si_transacc tcc ON (tcc.numero = tfun.transacc)
			LEFT OUTER JOIN bdicred:sd_msi_cancela_credito_msi mccm ON (mccm.num_credito = pm.num_sol_prestamo)
			LEFT JOIN bdicred:sd_amortiza_creditocrd ac ON (ac.num_credito = pm.num_sol_prestamo AND ac.fecha_cuota = movd.fecha_mov)
			LEFT JOIN intercard:movimiento imov ON (imov.secuenciaextendida = pm.folio_movto)
			WHERE pm.empresa = pEmpresa
			AND pm.num_credito = pNumCredito
			AND pm.num_pro_prestamo = 8900
			AND movd.fecha_mov BETWEEN pFechaInicial AND pFechaFinal
			AND tcc.se_emite_edocta = "S"
			AND movd.reversado = "N"

			UNION ALL
			SELECT 
				movd.secuencia, movd.fecha_mov, 
				CASE WHEN NVL(TRIM(movd.referencia),'') = '' THEN tfun.transacc ELSE TRIM(movd.referencia) END CASE,
				tfun.descripcion, tcc.naturaleza, movd.monto, movd.referencia23, movd.rfc_comer, tcc.numero, '' as num_tarjeta, 'S' as tipo_tarjeta, movd.folio_suc, 
				ac.num_pago as numpago, mae.plazo, imov.infreceptor, mccm.fecha_cancela, mccm.motivo_de_cancelacion
			FROM bdicred:sd_promocion_credito pm
			INNER JOIN bdicred:sd_maecredcrd mae ON (pm.num_sol_prestamo = mae.num_credito)
			INNER JOIN bdicred:sd_movhiscrd movd ON (movd.num_credito = pm.num_sol_prestamo)
			INNER JOIN bdicred:sd_transfun tfun ON (tfun.codigo_fun = movd.codigo_fun AND tfun.codigo_ref = movd.codigo_ref)
			INNER JOIN bdinteg:si_transacc tcc ON (tcc.numero = tfun.transacc)
			LEFT OUTER JOIN bdicred:sd_msi_cancela_credito_msi mccm ON (mccm.num_credito = pm.num_sol_prestamo)
			LEFT JOIN bdicred:sd_amortiza_creditocrd ac ON (ac.num_credito = pm.num_sol_prestamo AND ac.fecha_cuota = movd.fecha_mov)
			LEFT JOIN intercard:movimiento imov ON (imov.secuenciaextendida = pm.folio_movto)
			WHERE pm.empresa = pEmpresa
			AND pm.num_credito = pNumCredito
			AND pm.num_pro_prestamo = 8900
			AND movd.fecha_mov BETWEEN pFechaInicial AND pFechaFinal
			AND tcc.se_emite_edocta = "S"
			AND movd.reversado = "N"
		) ORDER BY tipo_tarjeta DESC, num_tarjeta ASC, fecha_mov DESC, secuencia DESC
		
		LET iNumPago = NVL(iNumPago, 0);
		LET vComercio = TRIM(NVL(vComercio, ''));
		LET vReferencia = vComercio; /*TRIM(vRefTotal);*/
		LET cDescripcion = TRIM(cDescripcion);
		
        IF vnaturaleza = "C" THEN
           LET vmonto = (vmonto*(-1));
        END IF;
		
		CASE vTrans
			WHEN "4265" THEN --Compras MSI
				LET cDescripcion = "COMPRA MESES SIN INTERESES " || iPlazo || " MESES";
			
			WHEN "4250" THEN --Cancelacion: A SOLICITUD DEL CLIENTE
				LET cDescripcion = "Cancela MSI";
				
			WHEN "4260" THEN --Cancelacion: CANCELACION AUTOMATICA
				LET cDescripcion = "Cancel-atraso MSI";
			
			WHEN "4266" THEN --Pagos MSI
				LET cDescripcion = "SU PAGO TDC - MESES SIN INTERESES " || iNumPago || " de " || iPlazo;
			
			ELSE
				--Resto de transacciones a MSI: (4264, 4267, 4253, 4261)
		END CASE;
		

		RETURN vcodret, vfecha, vReferencia, cDescripcion, vnaturaleza, vmonto,vSdoDeudorMSI, vTerminacion, vTipo WITH RESUME;
		 
	END FOREACH;

	IF DBINFO("sqlca.sqlerrd2") <=	0 THEN
	   LET vcodret = "002"; --No existen registros con el filtro de consulta indicado.
	   RETURN vcodret, vfecha, vReferencia, cDescripcion, vnaturaleza, vmonto,vSdoDeudorMSI, vTerminacion, vTipo;
	END IF;

END
END PROCEDURE;